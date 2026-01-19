package app.usecase.order;

/**
 * ConfirmOrderUseCase
 * Flow: 
 */
public final class ConfirmOrderUseCase {

    private final ConfirmOrderRepository repository;

    public ConfirmOrderUseCase(ConfirmOrderRepository repository) {
        this.repository = repository;
    }

    public ConfirmOrderResult execute(ConfirmOrderInput input) throws Exception {
        return repository.call(input);
    }
}
