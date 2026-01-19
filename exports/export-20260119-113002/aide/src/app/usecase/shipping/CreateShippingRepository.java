package app.usecase.shipping;

public interface CreateShippingRepository {
    CreateShippingResult call(CreateShippingInput input) throws Exception;
}
