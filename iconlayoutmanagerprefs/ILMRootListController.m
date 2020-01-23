#include "ILMRootListController.h"
#include "../ILMPrefs.h"
#include <Preferences/PSSpecifier.h>

#define prefs [ILMPrefs sharedInstance]

@interface ILMRootListController : PSEditableListController

- (NSArray*)iconStates;

@end

@implementation ILMRootListController

- (NSArray*)iconStates {

	NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:kSpringBoardIconStateDirectory error:nil];

	NSString *prefix = @"IconState_";
	NSString *suffix = @".plist";

	NSMutableArray *iconStates = [NSMutableArray new];

	for (NSString *file in contents) {
		if ([file hasPrefix:prefix]) {
			NSString *name = [file substringFromIndex:prefix.length];
			[iconStates addObject:[name substringWithRange:NSMakeRange(0, name.length - suffix.length)]];
		}
	}

	return [iconStates autorelease];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];

	[selectedCell setSelected:NO animated:YES];

	if (indexPath.section == 0) {
		selectedCell.accessoryType = UITableViewCellAccessoryCheckmark;
		prefs.selectedState = selectedCell.textLabel.text;
	} else {
		[self addLayoutButtonPressed:selectedCell];
	}

	for (int i = 0; i < [tableView numberOfRowsInSection:0]; i++) {
		UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];

		if (![cell.textLabel.text isEqualToString:prefs.selectedState]) {
			cell.accessoryType = UITableViewCellAccessoryNone;
		}
	}
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {

	[cell setSelected:NO animated:NO];

	if ([cell.textLabel.text isEqualToString:prefs.selectedState]) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	}

}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row == 0) {
		return NO;
	} else {
		return YES;
	}
}

- (BOOL)tableView:(UITableView *)tableView canFocusRowAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (void)removedSpecifier:(PSSpecifier*)specifier {

	NSURL *directory = [NSURL fileURLWithPath:kSpringBoardIconStateDirectory];
	[[NSFileManager defaultManager] removeItemAtURL:[directory URLByAppendingPathComponent:[NSString stringWithFormat:@"IconState_%@.plist", [specifier name]]] error:nil];

	if ([prefs.selectedState isEqualToString:[specifier name]]) {
		prefs.selectedState = kSelectedStateDefaultKey;
	}
}

- (void)displayErrorWithTitle:(NSString*)title message:(NSString*)message {
	UIAlertController * alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
	[alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];

	[self presentViewController:alertController animated:YES completion:nil];
}

- (void)addLayoutButtonPressed:(UITableViewCell*)cell {
	UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"New Layout" message: @"Enter name for new layout" preferredStyle:UIAlertControllerStyleAlert];

	[alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {

	}];

	[alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {

	}]];

	[alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {

		NSString *name = alertController.textFields[0].text;

		if ([name isEqualToString:kSelectedStateDefaultKey]) {
			[self displayErrorWithTitle:@"Not Allowed" message:@"The layout name you entered is not allowed."];
			return;
		}

		for (NSString *state in [self iconStates]) {
			if ([state isEqualToString:name]) {
				[self displayErrorWithTitle:@"Name Used" message:@"The layout name you entered is already being used."];
				return;
			}
		}

		if (![[name stringByTrimmingCharactersInSet:[NSCharacterSet alphanumericCharacterSet]] isEqualToString:@""]) {
			[self displayErrorWithTitle:@"Invalid Character" message:@"The layout name you entered contains an invalid character."];
			return;
		}

		NSURL *directory = [NSURL fileURLWithPath:kSpringBoardIconStateDirectory];
		NSError *error = nil;

		[[NSFileManager defaultManager] copyItemAtURL:[prefs selectedPlistURL] toURL:[directory URLByAppendingPathComponent:[NSString stringWithFormat:@"IconState_%@.plist", name]] error:&error];

		if (error) {
			[self displayErrorWithTitle:@"Error" message:[error description]];
			return;
		}

		prefs.selectedState = name;

		[self reloadSpecifiers];
	}]];

	[self presentViewController:alertController animated:YES completion:nil];

}

- (NSArray *)specifiers {

	if (_specifiers == nil) {
		_specifiers = [NSMutableArray new];

		PSSpecifier *defaultState = [PSSpecifier preferenceSpecifierNamed:@"Default"
																														target:self
																															 set:NULL
																															 get:NULL
																														detail:nil
																															cell:PSListItemCell
																															edit:nil];

		[_specifiers addObject:defaultState];

		for (NSString *stateName in [self iconStates]) {
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:stateName
																															target:self
																																 set:NULL
																																 get:NULL
																															detail:nil
																																cell:PSListItemCell
																																edit:nil];

			[specifier setProperty:NSStringFromSelector(@selector(removedSpecifier:)) forKey:PSDeletionActionKey];
			[_specifiers addObject:specifier];
		}

		PSSpecifier *group = [PSSpecifier preferenceSpecifierNamed:nil
																												target:self
																													 set:NULL
																													 get:NULL
																												detail:nil
																													cell:PSGroupCell
																													edit:nil];

		PSSpecifier *saveButton = [PSSpecifier preferenceSpecifierNamed:@"Add New Layout"
																												target:self
																													 set:NULL
																													 get:NULL
																												detail:nil
																													cell:PSButtonCell
																													edit:nil];

		[_specifiers addObject:group];
		[_specifiers addObject:saveButton];
	}

	return _specifiers;
}

@end
