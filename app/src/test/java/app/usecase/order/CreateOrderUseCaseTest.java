package app.usecase.order;

import app.domain.exception.ValidationException;
import org.junit.Test;

import static org.junit.Assert.*;

public class CreateOrderUseCaseTest {

    @Test
    public void valid_input_should_call_repository() throws Exception {
        CreateOrderRepository repo = input -> new CreateOrderResult();
        CreateOrderUseCase uc = new CreateOrderUseCase(repo);

        CreateOrderInput input = new CreateOrderInput();
        input.setOrderNo("ORD-1");

        assertNotNull(uc.execute(input));
    }

    @Test(expected = ValidationException.class)
    public void invalid_input_should_throw_validation_error() throws Exception {
        CreateOrderRepository repo = input -> new CreateOrderResult();
        CreateOrderUseCase uc = new CreateOrderUseCase(repo);

        uc.execute(new CreateOrderInput());
    }
}
