package app.usecase.billing;

/**
 * GetInvoiceListUseCase
 * Flow: 
 */
public final class GetInvoiceListUseCase {

    private final GetInvoiceListRepository repository;

    public GetInvoiceListUseCase(GetInvoiceListRepository repository) {
        this.repository = repository;
    }

    public GetInvoiceListResult execute(GetInvoiceListInput input) throws Exception {
        return repository.call(input);
    }
}
