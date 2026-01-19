package app.ui.fragment;

import android.os.Bundle;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Toast;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import app.R;
import app.ui.viewmodel.CreateInvoiceViewModel;

public final class CreateInvoiceFragment extends Fragment implements CreateInvoiceViewModel.UiCallbacks {

    private CreateInvoiceViewModel vm;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_create_invoice, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        vm = new CreateInvoiceViewModel(this);

        view.findViewById(R.id.btn_submit).setOnClickListener(v -> {
            CreateInvoiceViewModel.Input in = new CreateInvoiceViewModel.Input();

            in.billing_no = ((android.widget.EditText)view.findViewById(R.id.input_billing_no)).getText().toString();
            in.order_no = ((android.widget.EditText)view.findViewById(R.id.input_order_no)).getText().toString();
            vm.submit(in);
        });
    }

    @Override
    public void onValidationError(String fieldId, String message) {
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
