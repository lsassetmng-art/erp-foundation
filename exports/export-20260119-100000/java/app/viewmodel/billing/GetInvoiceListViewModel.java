package app.viewmodel.billing;

import androidx.lifecycle.ViewModel;
import app.usecase.billing.GetInvoiceListUseCase;
import app.repository.RepositoryProvider;

public final class GetInvoiceListViewModel extends ViewModel {
    // BINDING READY
    // TODO: expose execute() via LiveData / StateFlow


    private final GetInvoiceListUseCase useCase;

    public GetInvoiceListViewModel() {
        this.useCase = new GetInvoiceListUseCase(
            RepositoryProvider.provide(
                GetInvoiceListUseCase.class
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
