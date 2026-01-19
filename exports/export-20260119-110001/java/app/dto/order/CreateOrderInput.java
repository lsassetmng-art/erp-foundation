package app.dto.order;

public final class CreateOrderInput {
    private String value;
    private int quantity;
    public String getValue() { return value; }
    public void setValue(String value) { this.value = value; }
    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }
    public void validate() {
        if (value == null || value.trim().isEmpty()) throw new IllegalArgumentException("value required");
        if (quantity <= 0) throw new IllegalArgumentException("quantity must be > 0");
    }
}
