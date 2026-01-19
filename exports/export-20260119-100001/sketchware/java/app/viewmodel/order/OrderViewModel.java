package app.viewmodel.order;

import app.ui.common.BaseViewModel;
import app.usecase.order.CreateOrderInput;
import app.usecase.order.CreateOrderResult;
import app.usecase.order.CreateOrderUseCase;

/**
 * OrderViewModel
 *
 * - UI → ViewModel → UseCase
 * - company_id は一切扱わない
 */
public final class OrderViewModel extends BaseViewModel {
    // BINDING READY
    // TODO: expose execute() via LiveData / StateFlow


    private final CreateOrderUseCase createOrderUseCase;

    private CreateOrderResult lastResult;

    public OrderViewModel(CreateOrderUseCase useCase) {
        this.createOrderUseCase = useCase;
    
    public Object executeSafe(Object input) throws Exception {
        try {
            // DTO validation
            try {
                input.getClass().getMethod("validate").invoke(input);
            } catch (NoSuchMethodException ignore) {}
            return execute(input);
        } catch (IllegalArgumentException e) {
            throw e;
        }
    }

}

    public void createOrder(String itemCode, Integer qty) {
        try {
            setLoading(true);
            setErrorMessage(null);

            CreateOrderInput input =
                    new CreateOrderInput(itemCode, qty);

            lastResult = createOrderUseCase.execute(input);

        } catch (Exception e) {
            setErrorMessage(e.getMessage());
        } finally {
            setLoading(false);
        }
    }

    public CreateOrderResult getLastResult() {
        return lastResult;
    }
}
