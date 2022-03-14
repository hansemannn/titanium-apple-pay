/**
 * Titanium Apple Pay
 * Copyright (c) 2015-Present by Hans Knoechel. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiApplepayContact.h"
#import <Contacts/Contacts.h>
#import <Contacts/ContactsDefines.h>
@import TitaniumKit;

@implementation TiApplepayContact

#ifdef USE_TI_CONTACTSPERSON
- (id)TiApplePay_initWithPerson:(TiContactsPerson *)_person
{
  if (self = [super init]) {
    person = _person;
    [self initializePropertiesFromTiPerson];
  }

  return self;
}
#endif

- (id)initWithDictionary:(NSDictionary *)_dictionary
{
  if (self = [super init]) {
    dictionary = _dictionary;
    [self initializePropertiesFromDictionary];
  }

  return self;
}

#ifdef USE_TI_CONTACTSPERSON
- (void)initializePropertiesFromTiPerson
{
  NSPersonNameComponents *nameComponents = [[NSPersonNameComponents alloc] init];
  nameComponents.givenName = [person valueForKey:@"firstName"];
  nameComponents.middleName = [person valueForKey:@"middleName"];
  nameComponents.familyName = [person valueForKey:@"lastName"];
  nameComponents.nickname = [person valueForKey:@"nickname"];
  nameComponents.namePrefix = [person valueForKey:@"prefix"];
  nameComponents.nameSuffix = [person valueForKey:@"suffix"];

  NSArray<CNPostalAddress *> *postalAddresses = [person valueForKey:@"address"];

  if (postalAddresses != nil && [postalAddresses count] > 0) {
    // TODO: Handle postal address more accurate
    [self setPostalAddress:[postalAddresses valueForKey:@"home"]];
  }

  [self setName:nameComponents];

  // TODO: Handle email address more accurate
  [self setEmailAddress:[[[person valueForKey:@"email"] valueForKey:@"home"] objectAtIndex:0]];
}
#endif

- (void)initializePropertiesFromDictionary
{
  NSPersonNameComponents *nameComponents = [[NSPersonNameComponents alloc] init];
  nameComponents.givenName = [dictionary valueForKey:@"firstName"];
  nameComponents.middleName = [dictionary valueForKey:@"middleName"];
  nameComponents.familyName = [dictionary valueForKey:@"lastName"];
  nameComponents.namePrefix = [dictionary valueForKey:@"prefix"];
  nameComponents.nameSuffix = [dictionary valueForKey:@"suffix"];
  nameComponents.nickname = [dictionary valueForKey:@"nickname"];

  [self setName:nameComponents];

  NSDictionary *addressDict = [dictionary valueForKey:@"address"];
  CNPostalAddress *address = [[CNPostalAddress alloc] init];
  [address setValue:[addressDict valueForKey:@"street"] forKey:CNPostalAddressStreetKey];
  [address setValue:[addressDict valueForKey:@"city"] forKey:CNPostalAddressCityKey];
  [address setValue:[addressDict valueForKey:@"zip"] forKey:CNPostalAddressPostalCodeKey];
  [address setValue:[addressDict valueForKey:@"state"] forKey:CNPostalAddressStateKey];
  [address setValue:[addressDict valueForKey:@"country"] forKey:CNPostalAddressCountryKey];
  [address setValue:[addressDict valueForKey:@"ISOCountryCode"] forKey:CNPostalAddressISOCountryCodeKey];

  [self setPostalAddress:address];

  if ([TiUtils isIOSVersionOrGreater:@"9.2"]) {
    [self setSupplementarySubLocality:[addressDict valueForKey:@"supplementarySubLocality"]];
  }

  [self setEmailAddress:[dictionary valueForKey:@"email"]];
  [self setPhoneNumber:[CNPhoneNumber phoneNumberWithStringValue:[dictionary valueForKey:@"phone"]]];
}

@end
