package app.usecase.order;

import app.domain.exception.ValidationException;

public final class CreateOrderValidator {

    public void validate(CreateOrderInput input) throws ValidationException {
        if (input == null) {
            throw new ValidationException("input is required");
        }
        if (input.getOrderNo() == null || input.getOrderNo().isEmpty()) {
            throw new ValidationException("orderNo is required");
        }
    }
}
