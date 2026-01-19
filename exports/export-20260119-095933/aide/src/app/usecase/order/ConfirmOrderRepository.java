package app.usecase.order;

public interface ConfirmOrderRepository {
    ConfirmOrderResult call(ConfirmOrderInput input) throws Exception;
}
