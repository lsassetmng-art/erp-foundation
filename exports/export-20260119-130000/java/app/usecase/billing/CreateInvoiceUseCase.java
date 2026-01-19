package app.usecase.billing;

/**
 * CreateInvoiceUseCase
 * Flow: 
 */
public final class CreateInvoiceUseCase {

    private final CreateInvoiceRepository repository;

    public CreateInvoiceUseCase(CreateInvoiceRepository repository) {
        this.repository = repository;
    }

    public CreateInvoiceResult execute(CreateInvoiceInput input) throws Exception {
        return repository.call(input);
    }
}
