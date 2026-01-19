package app.usecase.shipping;

/**
 * CreateShippingUseCase
 * Flow: 
 */
public final class CreateShippingUseCase {

    private final CreateShippingRepository repository;

    public CreateShippingUseCase(CreateShippingRepository repository) {
        this.repository = repository;
    }

    public CreateShippingResult execute(CreateShippingInput input) throws Exception {
        return repository.call(input);
    }
}
