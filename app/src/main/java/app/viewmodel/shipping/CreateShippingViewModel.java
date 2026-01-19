package app.viewmodel.shipping;

import androidx.lifecycle.ViewModel;
import app.usecase.shipping.CreateShippingUseCase;
import app.repository.RepositoryProvider;

public final class CreateShippingViewModel extends ViewModel {
    // BINDING READY
    // TODO: expose execute() via LiveData / StateFlow


    private final CreateShippingUseCase useCase;

    public CreateShippingViewModel() {
        this.useCase = new CreateShippingUseCase(
            RepositoryProvider.provide(
                CreateShippingUseCase.class
            )
        );
    }

    public Object execute(Object input) throws Exception {
        return useCase.execute(input);
    }
}
