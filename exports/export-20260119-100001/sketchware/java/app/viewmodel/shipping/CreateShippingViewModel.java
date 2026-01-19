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
