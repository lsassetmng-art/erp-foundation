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
    }

    public Object execute(Object input) throws Exception {
        return useCase.execute(input);
    }
}
