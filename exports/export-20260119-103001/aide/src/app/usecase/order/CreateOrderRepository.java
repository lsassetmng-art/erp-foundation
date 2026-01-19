package app.usecase.order;

public interface CreateOrderRepository {
    CreateOrderResult call(CreateOrderInput input) throws Exception;
}
