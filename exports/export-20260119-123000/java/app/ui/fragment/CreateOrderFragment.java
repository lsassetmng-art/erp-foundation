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
import app.ui.dto.CreateOrderInput;
import app.ui.viewmodel.CreateOrderViewModel;

public final class CreateOrderFragment extends Fragment implements CreateOrderViewModel.UiCallbacks {

    private CreateOrderViewModel vm;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_createorder, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        vm = new CreateOrderViewModel(this);
        view.findViewById(R.id.btn_submit).setOnClickListener(v -> {
            CreateOrderInput input = new CreateOrderInput();
            EditText et_orderNo = view.findViewById(R.id.input_orderNo);
            String val_orderNo = (et_orderNo == null) ? "" : et_orderNo.getText().toString();
            input.setOrderNo(val_orderNo);
            EditText et_quantity = view.findViewById(R.id.input_quantity);
            Integer val_quantity = null;
            try {
                String s = (et_quantity == null) ? "" : et_quantity.getText().toString().trim();
                val_quantity = TextUtils.isEmpty(s) ? null : Integer.parseInt(s);
            } catch (Exception ignore) { val_quantity = null; }
            input.setQuantity(val_quantity);
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