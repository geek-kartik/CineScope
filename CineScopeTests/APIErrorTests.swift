//
//  APIErrorTests.swift
//  CineScopeTests
//

import Testing
import Foundation
@testable import CineScope

struct APIErrorTests {

    @Test func testErrorDescriptions() {
        #expect(APIError.missingCredentials.errorDescription?.contains("credentials") == true)
        #expect(APIError.invalidURL.errorDescription?.contains("URL") == true)
        #expect(APIError.unauthorized.errorDescription?.contains("401") == true)
        #expect(APIError.forbidden.errorDescription?.contains("403") == true)
        #expect(APIError.notFound.errorDescription?.contains("not found") == true)
        #expect(APIError.rateLimited.errorDescription?.contains("429") == true)
        #expect(APIError.serverError(statusCode: 500).errorDescription?.contains("500") == true)
        #expect(APIError.offline.errorDescription?.contains("internet") == true)
    }

    @Test func testIsAuthError() {
        #expect(APIError.missingCredentials.isAuthError == true)
        #expect(APIError.unauthorized.isAuthError == true)
        #expect(APIError.forbidden.isAuthError == true)
        #expect(APIError.notFound.isAuthError == false)
        #expect(APIError.serverError(statusCode: 500).isAuthError == false)
    }
}
