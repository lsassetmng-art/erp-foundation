package app.usecase.billing;

public interface CreateInvoiceRepository {
    CreateInvoiceResult call(CreateInvoiceInput input) throws Exception;
}
