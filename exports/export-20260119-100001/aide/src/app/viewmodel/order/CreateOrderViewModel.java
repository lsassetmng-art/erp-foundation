package app.viewmodel.order;

import androidx.lifecycle.ViewModel;
import app.usecase.order.CreateOrderUseCase;
import app.repository.RepositoryProvider;

public final class CreateOrderViewModel extends ViewModel {
    // BINDING READY
    // TODO: expose execute() via LiveData / StateFlow


    private final CreateOrderUseCase useCase;

    public CreateOrderViewModel() {
        this.useCase = new CreateOrderUseCase(
            RepositoryProvider.provide(
                CreateOrderUseCase.class
            )
        );
    
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

    public Object execute(Object input) throws Exception {
        return useCase.execute(input);
    }
}
