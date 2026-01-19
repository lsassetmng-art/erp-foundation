package app.ui.order;

import app.viewmodel.order.OrderViewModel;

/**
 * OrderScreen（UI雛形）
 *
 * - Android Activity / Fragment / Sketchware から呼ばれる想定
 * - UIイベント → ViewModel を叩くだけ
 */
public final class OrderScreen {

    private final OrderViewModel viewModel;

    public OrderScreen(OrderViewModel viewModel) {
        this.viewModel = viewModel;
    }

    public void onCreateOrderClicked(String itemCode, int qty) {
        viewModel.createOrder(itemCode, qty);
    }

    public void render() {
        if (viewModel.isLoading()) {
            // show loading
        } else if (viewModel.getErrorMessage() != null) {
            // show error
        } else {
            // show success
        }
    }
}
