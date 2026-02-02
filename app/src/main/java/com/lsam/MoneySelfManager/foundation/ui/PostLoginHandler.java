package com.lsam.MoneySelfManager.foundation.ui;

import android.content.Context;

import com.lsam.MoneySelfManager.foundation.model.LoginResult;

public interface PostLoginHandler {
    void onLoginSuccess(Context context, LoginResult result);
}
