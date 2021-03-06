/*
 * The MIT License (MIT)
 *
 * Copyright (c) 2017 NBCO Yandex.Money LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import typealias FunctionalSwift.Result
import OHHTTPStubs
import XCTest
@testable import YandexCheckoutWalletApi
import YandexMoneyTestInstrumentsApi

class CheckoutAuthSessionGenerateTests: ApiMethodTestCase {

    struct CheckoutAuthSessionGenerateErrorResponse: StubsResponse {}
    struct CheckoutAuthSessionGenerateSuccessResponse: StubsResponse {}
    struct CheckoutAuthSessionGenerateEmergencyWithCodeLengthSuccessResponse: StubsResponse {}
    struct CheckoutAuthSessionGenerateEmergencyNoCodeLengthSuccessResponse: StubsResponse {}

    func testCheckoutAuthSessionGenerateErrorResponse() {
        validate(CheckoutAuthSessionGenerateErrorResponse.self) {
            guard case .left(CheckoutAuthSessionGenerateError.createTimeoutNotExpired) = $0 else {
                XCTFail("Wrong result")
                return
            }
        }
    }

    func testCheckoutAuthSessionGenerateSuccessResponse() {
        validate(CheckoutAuthSessionGenerateSuccessResponse.self) {
            guard case .right(let authSessionGenerate) = $0 else {
                XCTFail("Wrong result")
                return
            }
            let result = authSessionGenerate.result

            XCTAssertEqual(result.specific.type, .sms, "Wrong type")

            guard case .sms(let smsDescription) = result.specific else {
                XCTFail("Wrong specific")
                return
            }

            XCTAssertEqual(smsDescription.codeLength, 6, "Wrong codeLength")
            XCTAssertEqual(smsDescription.sessionsLeft, 13, "Wrong sessionsLeft")
            XCTAssertEqual(smsDescription.sessionTimeLeft, 20, "Wrong sessionTimeLeft")
            XCTAssertEqual(smsDescription.nextSessionTimeLeft, 30, "Wrong nextSessionTimeLeft")

            guard let activeSession = result.activeSession else {
                XCTFail("Wrong active session")
                return
            }

            XCTAssertEqual(activeSession.attemptsCount, 10, "Wrong attemptsCount")
            XCTAssertEqual(activeSession.attemptsLeft, 11, "Wrong attemptsLeft")

            XCTAssertEqual(result.canBeIssued, false, "Wrong canBeIssued")
            XCTAssertEqual(result.enabled, true, "Wrong enabled")
            XCTAssertEqual(result.isSessionRequired, true, "Wrong isSessionRequired")
        }
    }

    func testCheckoutAuthSessionGenerateEmergencyWithCodeLengthSuccessResponse() {
        validate(CheckoutAuthSessionGenerateEmergencyWithCodeLengthSuccessResponse.self) {
            guard case .right(let authSessionGenerate) = $0 else {
                XCTFail("Wrong result")
                return
            }
            let result = authSessionGenerate.result
            guard case .emergency = result.specific else {
                XCTFail("Wrong specific")
                return
            }
        }
    }

    func testCheckoutAuthSessionGenerateEmergencyNoCodeLengthSuccessResponse() {
        validate(CheckoutAuthSessionGenerateEmergencyNoCodeLengthSuccessResponse.self) {
            guard case .right(let authSessionGenerate) = $0 else {
                XCTFail("Wrong result")
                return
            }
            let result = authSessionGenerate.result
            guard case .emergency = result.specific else {
                XCTFail("Wrong specific")
                return
            }
        }
    }
}

private extension CheckoutAuthSessionGenerateTests {

    func validate(_ stubsResponse: StubsResponse.Type,
                  verify: @escaping (Result<CheckoutAuthSessionGenerate>) -> Void) {
        let method = CheckoutAuthSessionGenerate.Method(passportAuthorization: "",
                                                        merchantClientAuthorization: "",
                                                        authContextId: "",
                                                        authType: .sms)
        validate(method, stubsResponse, CheckoutAuthSessionGenerateTests.self, verify: verify)
    }
}
