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

    private final CreateOrderUseCase createOrderUseCase;

    private CreateOrderResult lastResult;

    public OrderViewModel(CreateOrderUseCase useCase) {
        this.createOrderUseCase = useCase;
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
