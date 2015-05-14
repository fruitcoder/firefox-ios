//
//  ErrorPageHelper.swift
//  Client
//
//  Created by Wes Johnston on 5/13/15.
//  Copyright (c) 2015 Mozilla. All rights reserved.
//

import Foundation
import WebKit
import Shared

private let server: GCDWebServer = GCDWebServer()

class ErrorPageHelper {
    // When an error page is intentionally loaded, its added to this set. If its in the set, we show
    // it as an error page. If its not, we assume someone is trying to reload this page somehow, and
    // we'll instead redirect back to the original URL.
    private static var redirecting = [NSURL]()

    class func cfErrorToName(err: CFNetworkErrors) -> String {
        switch err {
        case .CFHostErrorHostNotFound: return "CFHostErrorHostNotFound"
        case .CFHostErrorUnknown: return "CFHostErrorUnknown"
        case .CFSOCKSErrorUnknownClientVersion: return "CFSOCKSErrorUnknownClientVersion"
        case .CFSOCKSErrorUnsupportedServerVersion: return "CFSOCKSErrorUnsupportedServerVersion"
        case .CFSOCKS4ErrorRequestFailed: return "CFSOCKS4ErrorRequestFailed"
        case .CFSOCKS4ErrorIdentdFailed: return "CFSOCKS4ErrorIdentdFailed"
        case .CFSOCKS4ErrorIdConflict: return "CFSOCKS4ErrorIdConflict"
        case .CFSOCKS4ErrorUnknownStatusCode: return "CFSOCKS4ErrorUnknownStatusCode"
        case .CFSOCKS5ErrorBadState: return "CFSOCKS5ErrorBadState"
        case .CFSOCKS5ErrorBadResponseAddr: return "CFSOCKS5ErrorBadResponseAddr"
        case .CFSOCKS5ErrorBadCredentials: return "CFSOCKS5ErrorBadCredentials"
        case .CFSOCKS5ErrorUnsupportedNegotiationMethod: return "CFSOCKS5ErrorUnsupportedNegotiationMethod"
        case .CFSOCKS5ErrorNoAcceptableMethod: return "CFSOCKS5ErrorNoAcceptableMethod"
        case .CFFTPErrorUnexpectedStatusCode: return "CFFTPErrorUnexpectedStatusCode"
        case .CFErrorHTTPAuthenticationTypeUnsupported: return "CFErrorHTTPAuthenticationTypeUnsupported"
        case .CFErrorHTTPBadCredentials: return "CFErrorHTTPBadCredentials"
        case .CFErrorHTTPConnectionLost: return "CFErrorHTTPConnectionLost"
        case .CFErrorHTTPParseFailure: return "CFErrorHTTPParseFailure"
        case .CFErrorHTTPRedirectionLoopDetected: return "CFErrorHTTPRedirectionLoopDetected"
        case .CFErrorHTTPBadURL: return "CFErrorHTTPBadURL"
        case .CFErrorHTTPProxyConnectionFailure: return "CFErrorHTTPProxyConnectionFailure"
        case .CFErrorHTTPBadProxyCredentials: return "CFErrorHTTPBadProxyCredentials"
        case .CFErrorPACFileError: return "CFErrorPACFileError"
        case .CFErrorPACFileAuth: return "CFErrorPACFileAuth"
        case .CFErrorHTTPSProxyConnectionFailure: return "CFErrorHTTPSProxyConnectionFailure"
        case .CFStreamErrorHTTPSProxyFailureUnexpectedResponseToCONNECTMethod: return "CFStreamErrorHTTPSProxyFailureUnexpectedResponseToCONNECTMethod"

        case .CFURLErrorBackgroundSessionInUseByAnotherProcess: return "CFURLErrorBackgroundSessionInUseByAnotherProcess"
        case .CFURLErrorBackgroundSessionWasDisconnected: return "CFURLErrorBackgroundSessionWasDisconnected"
        case .CFURLErrorUnknown: return "CFURLErrorUnknown"
        case .CFURLErrorCancelled: return "CFURLErrorCancelled"
        case .CFURLErrorBadURL: return "CFURLErrorBadURL"
        case .CFURLErrorTimedOut: return "CFURLErrorTimedOut"
        case .CFURLErrorUnsupportedURL: return "CFURLErrorUnsupportedURL"
        case .CFURLErrorCannotFindHost: return "CFURLErrorCannotFindHost"
        case .CFURLErrorCannotConnectToHost: return "CFURLErrorCannotConnectToHost"
        case .CFURLErrorNetworkConnectionLost: return "CFURLErrorNetworkConnectionLost"
        case .CFURLErrorDNSLookupFailed: return "CFURLErrorDNSLookupFailed"
        case .CFURLErrorHTTPTooManyRedirects: return "CFURLErrorHTTPTooManyRedirects"
        case .CFURLErrorResourceUnavailable: return "CFURLErrorResourceUnavailable"
        case .CFURLErrorNotConnectedToInternet: return "CFURLErrorNotConnectedToInternet"
        case .CFURLErrorRedirectToNonExistentLocation: return "CFURLErrorRedirectToNonExistentLocation"
        case .CFURLErrorBadServerResponse: return "CFURLErrorBadServerResponse"
        case .CFURLErrorUserCancelledAuthentication: return "CFURLErrorUserCancelledAuthentication"
        case .CFURLErrorUserAuthenticationRequired: return "CFURLErrorUserAuthenticationRequired"
        case .CFURLErrorZeroByteResource: return "CFURLErrorZeroByteResource"
        case .CFURLErrorCannotDecodeRawData: return "CFURLErrorCannotDecodeRawData"
        case .CFURLErrorCannotDecodeContentData: return "CFURLErrorCannotDecodeContentData"
        case .CFURLErrorCannotParseResponse: return "CFURLErrorCannotParseResponse"
        case .CFURLErrorInternationalRoamingOff: return "CFURLErrorInternationalRoamingOff"
        case .CFURLErrorCallIsActive: return "CFURLErrorCallIsActive"
        case .CFURLErrorDataNotAllowed: return "CFURLErrorDataNotAllowed"
        case .CFURLErrorRequestBodyStreamExhausted: return "CFURLErrorRequestBodyStreamExhausted"
        case .CFURLErrorFileDoesNotExist: return "CFURLErrorFileDoesNotExist"
        case .CFURLErrorFileIsDirectory: return "CFURLErrorFileIsDirectory"
        case .CFURLErrorNoPermissionsToReadFile: return "CFURLErrorNoPermissionsToReadFile"
        case .CFURLErrorDataLengthExceedsMaximum: return "CFURLErrorDataLengthExceedsMaximum"
        case .CFURLErrorSecureConnectionFailed: return "CFURLErrorSecureConnectionFailed"
        case .CFURLErrorServerCertificateHasBadDate: return "CFURLErrorServerCertificateHasBadDate"
        case .CFURLErrorServerCertificateUntrusted: return "CFURLErrorServerCertificateUntrusted"
        case .CFURLErrorServerCertificateHasUnknownRoot: return "CFURLErrorServerCertificateHasUnknownRoot"
        case .CFURLErrorServerCertificateNotYetValid: return "CFURLErrorServerCertificateNotYetValid"
        case .CFURLErrorClientCertificateRejected: return "CFURLErrorClientCertificateRejected"
        case .CFURLErrorClientCertificateRequired: return "CFURLErrorClientCertificateRequired"
        case .CFURLErrorCannotLoadFromNetwork: return "CFURLErrorCannotLoadFromNetwork"
        case .CFURLErrorCannotCreateFile: return "CFURLErrorCannotCreateFile"
        case .CFURLErrorCannotOpenFile: return "CFURLErrorCannotOpenFile"
        case .CFURLErrorCannotCloseFile: return "CFURLErrorCannotCloseFile"
        case .CFURLErrorCannotWriteToFile: return "CFURLErrorCannotWriteToFile"
        case .CFURLErrorCannotRemoveFile: return "CFURLErrorCannotRemoveFile"
        case .CFURLErrorCannotMoveFile: return "CFURLErrorCannotMoveFile"
        case .CFURLErrorDownloadDecodingFailedMidStream: return "CFURLErrorDownloadDecodingFailedMidStream"
        case .CFURLErrorDownloadDecodingFailedToComplete: return "CFURLErrorDownloadDecodingFailedToComplete"

        case .CFHTTPCookieCannotParseCookieFile: return "CFHTTPCookieCannotParseCookieFile"
        case .CFNetServiceErrorUnknown: return "CFNetServiceErrorUnknown"
        case .CFNetServiceErrorCollision: return "CFNetServiceErrorCollision"
        case .CFNetServiceErrorNotFound: return "CFNetServiceErrorNotFound"
        case .CFNetServiceErrorInProgress: return "CFNetServiceErrorInProgress"
        case .CFNetServiceErrorBadArgument: return "CFNetServiceErrorBadArgument"
        case .CFNetServiceErrorCancel: return "CFNetServiceErrorCancel"
        case .CFNetServiceErrorInvalid: return "CFNetServiceErrorInvalid"
        case .CFNetServiceErrorTimeout: return "CFNetServiceErrorTimeout"
        case .CFNetServiceErrorDNSServiceFailure: return "CFNetServiceErrorDNSServiceFailure"
        default: return "Unknown"
        }
    }

    class func register(server: WebServer) {
        server.registerHandlerForMethod("GET", module: "errors", resource: "error.html", handler: { (request) -> GCDWebServerResponse! in
            let urlString = request.query["url"] as? String
            let url = (NSURL(string: urlString?.unescape() ?? "") ?? NSURL(string: ""))!

            if let index = find(self.redirecting, url) {
                self.redirecting.removeAtIndex(index)

                let errCode = (request.query["code"] as! String).toInt()
                let errDescription = request.query["description"] as! String
                var errDomain = request.query["domain"] as! String
                if let code = CFNetworkErrors(rawValue: Int32(errCode!)) {
                    errDomain = self.cfErrorToName(code)
                }

                let tryAgain = NSLocalizedString("Try again", tableName: "errorPages", comment: "Shown in error pages on a button that will try to load the page again")

                let asset = NSBundle.mainBundle().pathForResource("NetError", ofType: "html")
                let response = GCDWebServerDataResponse(HTMLTemplate: asset, variables: [
                    "error_code": "\(errCode ?? -1)",
                    "error_title": errDescription ?? "",
                    "long_description": nil ?? "",
                    "short_description": errDomain,
                    "actions": "<button onclick='window.location.reload()'>\(tryAgain)</button>" // This
                ])
                response.setValue("no cache", forAdditionalHeader: "Pragma")
                response.setValue("no-cache,must-revalidate", forAdditionalHeader: "Cache-Control")
                response.setValue(NSDate().description, forAdditionalHeader: "Expires")
                return response
            } else {
                return GCDWebServerDataResponse(redirect: url, permanent: false)
            }
        })

        server.registerHandlerForMethod("GET", module: "errors", resource: "NetError.css", handler: { (request) -> GCDWebServerResponse! in
            let path = NSBundle(forClass: self).pathForResource("NetError", ofType: "css")!
            let data = NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding, error: nil)! as String
            return GCDWebServerDataResponse(data: NSData(contentsOfFile: path), contentType: "text/css")
        })
    }

    func showPage(error: NSError, forUrl url: NSURL, inWebView webView: WKWebView) {
        // Add this page to the redirecting list. This will cause the server to actually show the error page
        // (instead of redirecting to the original URL).
        ErrorPageHelper.redirecting.append(url)

        let errorUrl = "\(WebServer.sharedInstance.base)/errors/error.html?url=\(url.absoluteString?.escape() ?? String())&code=\(error.code)&domain=\(error.domain)&description=\(error.localizedDescription.escape())"
        let request = NSURLRequest(URL: errorUrl.asURL!)
        webView.loadRequest(request)
    }

    class func isErrorPageURL(url: NSURL) -> Bool {
        return startsWith(url.absoluteString!, "\(WebServer.sharedInstance.base)/errors/error.html")
    }

    class func decodeURL(url: NSURL) -> NSURL {
        let query = url.getQuery()
        let queryUrl = query["url"]
        return NSURL(string: query["url"]?.unescape() ?? "")!
    }
}