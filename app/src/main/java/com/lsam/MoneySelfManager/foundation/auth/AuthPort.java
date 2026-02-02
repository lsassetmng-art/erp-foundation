package com.lsam.MoneySelfManager.foundation.auth;

import com.lsam.MoneySelfManager.foundation.model.LoginResult;

public interface AuthPort {
    LoginResult login(String email, String password);
    LoginResult getCurrentSession();
    void logout();
}
