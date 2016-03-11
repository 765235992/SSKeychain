//
//  KeychainTests.swift
//  SSKeychain
//
//  Created by Sam Soffes on 3/10/16.
//  Copyright © 2010-2016 Sam Soffes. All rights reserved.
//

import XCTest
import SSKeychain

class KeychainTests: XCTestCase {

	let testServiceName = "SSToolkitTestService"
	let testAccountName = "SSToolkitTestAccount"
	let testPassword = "SSToolkitTestPassword"
	let testLabel = "SSToolkitLabel"

	func testNewItem() {
		// New item
		let newQuery = SSKeychainQuery()
		newQuery.password = testPassword
		newQuery.service = testServiceName
		newQuery.account = testAccountName
		newQuery.label = testLabel
		try! newQuery.save()

		// Look up
		let lookupQuery = SSKeychainQuery()
		lookupQuery.service = testServiceName
		lookupQuery.account = testAccountName
		try! lookupQuery.fetch()

		XCTAssertEqual(newQuery.password, lookupQuery.password)

		// Search for all accounts
		let allQuery = SSKeychainQuery()
		var accounts = try! allQuery.fetchAll()
		XCTAssertTrue(self.accounts(accounts, containsAccountWithName: testAccountName), "Matching account was not returned")

		// Check accounts for service
		allQuery.service = testServiceName
		accounts = try! allQuery.fetchAll()
		XCTAssertTrue(self.accounts(accounts, containsAccountWithName: testAccountName), "Matching account was not returned")

		// Delete
		let deleteQuery = SSKeychainQuery()
		deleteQuery.service = testServiceName
		deleteQuery.account = testAccountName
		try! deleteQuery.deleteItem()
	}

	func testPasswordObject() {
		let newQuery = SSKeychainQuery()
		newQuery.service = testServiceName
		newQuery.account = testAccountName

		let dictionary: [String: NSObject] = [
			"number": 42,
			"string": "Hello World"
		]

		newQuery.passwordObject = dictionary
		try! newQuery.save()

		let lookupQuery = SSKeychainQuery()
		lookupQuery.service = testServiceName
		lookupQuery.account = testAccountName
		try! lookupQuery.fetch()

		let readDictionary = lookupQuery.passwordObject as! [String: NSObject]
		XCTAssertEqual(dictionary, readDictionary)
	}

	func testMissingInformation() {
		var query = SSKeychainQuery()
		query.service = testServiceName
		query.account = testAccountName
		XCTAssertThrowsError(try query.save())

		query = SSKeychainQuery()
		query.account = testAccountName
		query.password = testPassword
		XCTAssertThrowsError(try query.save())

		query = SSKeychainQuery()
		query.service = testServiceName
		query.password = testPassword
		XCTAssertThrowsError(try query.save())
	}

	func testUpdateAccessibilityType() {
		SSKeychain.setAccessibilityType(kSecAttrAccessibleWhenUnlockedThisDeviceOnly)

		// Create a new item
		SSKeychain.setPassword(testPassword, forService: testServiceName, account: testAccountName)

		// Check all accounts
		XCTAssertTrue(accounts(SSKeychain.allAccounts(), containsAccountWithName: testAccountName))

		// Check account
		XCTAssertTrue(accounts(SSKeychain.accountsForService(testServiceName), containsAccountWithName: testAccountName))

		SSKeychain.setAccessibilityType(kSecAttrAccessibleAlwaysThisDeviceOnly)
		SSKeychain.setPassword(testPassword, forService: testServiceName, account: testAccountName)

		// Check all accounts
		XCTAssertTrue(accounts(SSKeychain.allAccounts(), containsAccountWithName: testAccountName))

		// Check account
		XCTAssertTrue(accounts(SSKeychain.accountsForService(testServiceName), containsAccountWithName: testAccountName))
	}
	

	// MARK: - Private

	private func accounts(accounts: [[String: AnyObject]], containsAccountWithName name: String) -> Bool {
		for account in accounts {
			if let acct = account["acct"] as? String where acct == name {
				return true
			}
		}

		return false
	}
}
