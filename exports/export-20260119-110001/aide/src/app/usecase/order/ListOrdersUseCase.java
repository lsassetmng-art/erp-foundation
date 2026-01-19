package app.usecase.order;

/**
 * ListOrdersUseCase
 * Flow: validate, list
 */
public final class ListOrdersUseCase {

    private final ListOrdersRepository repository;

    public ListOrdersUseCase(ListOrdersRepository repository) {
        this.repository = repository;
    }

    public ListOrdersResult execute(ListOrdersInput input) throws Exception {
        return repository.call(input);
    }
}
