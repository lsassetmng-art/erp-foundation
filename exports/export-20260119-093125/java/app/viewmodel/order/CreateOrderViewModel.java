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
    }

    public Object execute(Object input) throws Exception {
        return useCase.execute(input);
    }
}
