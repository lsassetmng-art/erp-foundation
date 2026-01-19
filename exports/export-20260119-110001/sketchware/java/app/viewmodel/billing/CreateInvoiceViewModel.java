package app.viewmodel.billing;

import androidx.lifecycle.ViewModel;
import app.usecase.billing.CreateInvoiceUseCase;
import app.repository.RepositoryProvider;

public final class CreateInvoiceViewModel extends ViewModel {
    // BINDING READY
    // TODO: expose execute() via LiveData / StateFlow


    private final CreateInvoiceUseCase useCase;

    public CreateInvoiceViewModel() {
        this.useCase = new CreateInvoiceUseCase(
            RepositoryProvider.provide(
                CreateInvoiceUseCase.class
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
