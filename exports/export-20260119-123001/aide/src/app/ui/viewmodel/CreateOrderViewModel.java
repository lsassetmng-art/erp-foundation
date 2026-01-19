package app.ui.viewmodel;

public class CreateOrderViewModel extends BaseViewModel {

    public void submit(Input input) {
        executeSafe(() -> {
            if (input.orderNo == null || input.orderNo.toString().isEmpty())
                throw new IllegalArgumentException("orderNo is required");
            if (input.orderNo.length() > 20)
                throw new IllegalArgumentException("orderNo too long");
            if (input.quantity == null || input.quantity.toString().isEmpty())
                throw new IllegalArgumentException("quantity is required");
            if (input.quantity < 1)
                throw new IllegalArgumentException("quantity too small");
        });
    }

    public static class Input {
        public String orderNo;
        public Integer quantity;
    }
}