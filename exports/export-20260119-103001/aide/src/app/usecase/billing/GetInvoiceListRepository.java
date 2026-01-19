package app.usecase.billing;

public interface GetInvoiceListRepository {
    GetInvoiceListResult call(GetInvoiceListInput input) throws Exception;
}
