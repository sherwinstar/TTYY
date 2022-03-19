//
//  TYAppleLoginHelper.swift
//  TTYY
//
//  Created by YJPRO on 2021/7/7.
//

import UIKit
import AuthenticationServices

protocol TYAppleLoginHelperProtocol: NSObjectProtocol {
    func appleLoginAuthrizationSuccess(params: [String: Any])
    func appleLoginAuthrizationFailed(error: String)
}

class TYAppleLoginHelper: NSObject {
    static let shared = TYAppleLoginHelper()
    weak var delegate: TYAppleLoginHelperProtocol?
    
    /// 处理苹果登录
    func handleAppleLoginAuthorization() {
        if #available (iOS 13, *) {
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = self
            authorizationController.performRequests()
        } else {
            delegate?.appleLoginAuthrizationFailed(error: "系统不支持Apple登录")
        }
    }
}

@available(iOS 13.0, *)
extension TYAppleLoginHelper: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        if let vc = delegate as? UIViewController {
            return vc.view.window ?? UIApplication.shared.keyWindow!
        }
        return UIApplication.shared.keyWindow!
    }
    
    /// 授权成功
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            // 苹果用户唯一标识符，该值在同一个开发者账号下的所有 App 下是一样的，开发者可以用该唯一标识符与自己后台系统的账号体系绑定起来。
            let user = appleIDCredential.user
            // 服务器验证需要使用的参数
            let identityToken = appleIDCredential.identityToken
            let authorizationCode = String(data: appleIDCredential.authorizationCode ?? Data(), encoding: String.Encoding.utf8)
            let realUserStatus = appleIDCredential.realUserStatus
            if realUserStatus == .unsupported {
                delegate?.appleLoginAuthrizationFailed(error: "授权无效，请重新登录")
            }
            let params = ["platform_uid" : user, "code" : authorizationCode ?? ""] as [String : Any]
            delegate?.appleLoginAuthrizationSuccess(params: params)
            print("identityToken:\(String(describing: identityToken))")
        } else if let passwordCredential = authorization.credential as? ASPasswordCredential {
            let username = passwordCredential.user
            let password = passwordCredential.password
            print("username:\(username)")
            print("password:\(password)")
            delegate?.appleLoginAuthrizationFailed(error: "授权无效，请重新登录")
        } else {
            delegate?.appleLoginAuthrizationFailed(error: "授权无效，请重新登录")
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        var errorMsg = ""
        var showMsg = "登录失败！"
        if let authError = error as? ASAuthorizationError {
            let code = authError.code
            switch code {
            case .canceled:
                errorMsg = "用户取消了授权请求"
                showMsg = "取消登录"
            case .failed:
                errorMsg = "授权请求失败"
            case .invalidResponse:
                errorMsg = "授权请求响应无效"
            case .notHandled:
                errorMsg = "未能处理授权请求"
            case .unknown:
                errorMsg = "授权请求失败, 未知的错误原因"
            default:
                errorMsg = "其他未知的错误原因"
            }
        }
        print("errorMsg = \(errorMsg)")
        delegate?.appleLoginAuthrizationFailed(error: showMsg)
    }
    
}
