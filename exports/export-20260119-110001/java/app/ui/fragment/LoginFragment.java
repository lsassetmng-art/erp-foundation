package app.ui.fragment;

import android.os.Bundle;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.EditText;
import android.widget.Toast;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import app.R;
import app.ui.dto.LoginInput;
import app.ui.viewmodel.LoginViewModel;

public final class LoginFragment extends Fragment implements LoginViewModel.UiCallbacks {

    private LoginViewModel vm;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_login, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        vm = new LoginViewModel(this);
        view.findViewById(R.id.btn_submit).setOnClickListener(v -> {
            LoginInput input = new LoginInput();
            EditText et_email = view.findViewById(R.id.input_email);
            String val_email = (et_email == null) ? "" : et_email.getText().toString();
            input.setEmail(val_email);
            EditText et_password = view.findViewById(R.id.input_password);
            String val_password = (et_password == null) ? "" : et_password.getText().toString();
            input.setPassword(val_password);
            vm.submit(input);
        });
    }

    @Override
    public void onFieldError(String fieldId, String message) {
        View root = getView();
        if (root == null) return;
        int resId = getResources().getIdentifier("input_" + fieldId, "id", requireContext().getPackageName());
        if (resId != 0) {
            View v = root.findViewById(resId);
            if (v instanceof EditText) ((EditText) v).setError(message);
        }
    }

    @Override
    public void onFormError(String message) {
        if (getContext() != null) Toast.makeText(getContext(), message, Toast.LENGTH_SHORT).show();
    }

    @Override
    public void onSystemError(Exception e) {
        if (getContext() != null) Toast.makeText(getContext(), "System error: " + e.getMessage(), Toast.LENGTH_SHORT).show();
    }

    @Override
    public void onSuccess() {
        if (getContext() != null) Toast.makeText(getContext(), "OK", Toast.LENGTH_SHORT).show();
    }
}