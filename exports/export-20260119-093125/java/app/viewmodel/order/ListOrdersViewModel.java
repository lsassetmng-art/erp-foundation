package app.viewmodel.order;

import androidx.lifecycle.ViewModel;
import app.usecase.order.ListOrdersUseCase;
import app.repository.RepositoryProvider;

public final class ListOrdersViewModel extends ViewModel {
    // BINDING READY
    // TODO: expose execute() via LiveData / StateFlow


    private final ListOrdersUseCase useCase;

    public ListOrdersViewModel() {
        this.useCase = new ListOrdersUseCase(
            RepositoryProvider.provide(
                ListOrdersUseCase.class
            )
        );
    }

    public Object execute(Object input) throws Exception {
        return useCase.execute(input);
    }
}
