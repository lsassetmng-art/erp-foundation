package app.usecase.order;

public interface ListOrdersRepository {
    ListOrdersResult call(ListOrdersInput input) throws Exception;
}
