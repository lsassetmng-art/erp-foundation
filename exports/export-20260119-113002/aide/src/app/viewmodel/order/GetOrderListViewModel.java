package app.viewmodel.order;

import androidx.lifecycle.ViewModel;
import app.usecase.order.GetOrderListUseCase;
import app.repository.RepositoryProvider;

public final class GetOrderListViewModel extends ViewModel {
    // BINDING READY
    // TODO: expose execute() via LiveData / StateFlow


    private final GetOrderListUseCase useCase;

    public GetOrderListViewModel() {
        this.useCase = new GetOrderListUseCase(
            RepositoryProvider.provide(
                GetOrderListUseCase.class
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
