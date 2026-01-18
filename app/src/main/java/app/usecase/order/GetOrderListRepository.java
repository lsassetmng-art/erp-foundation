package app.usecase.order;

public interface GetOrderListRepository {
    GetOrderListResult call(GetOrderListInput input) throws Exception;
}
