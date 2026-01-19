package app.usecase.order;

/**
 * GetOrderListUseCase
 * Flow: 
 */
public final class GetOrderListUseCase {

    private final GetOrderListRepository repository;

    public GetOrderListUseCase(GetOrderListRepository repository) {
        this.repository = repository;
    }

    public GetOrderListResult execute(GetOrderListInput input) throws Exception {
        return repository.call(input);
    }
}
