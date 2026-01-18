package app.usecase.order;

/**
 * CreateOrderUseCase
 * Flow: validate, create
 */
public final class CreateOrderUseCase {

    private final CreateOrderRepository repository;

    public CreateOrderUseCase(CreateOrderRepository repository) {
        this.repository = repository;
    }

    public CreateOrderResult execute(CreateOrderInput input) throws Exception {
        return repository.call(input);
    }
}
