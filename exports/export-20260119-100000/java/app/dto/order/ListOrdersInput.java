package app.dto.order;

public final class ListOrdersInput {

    // TODO: フィールドは後で拡張（今は共通1項目）
    private String value;

    public String getValue() {
        return value;
    
    public void validate() {
        if (value == null || value.trim().isEmpty()) {
            throw new IllegalArgumentException("Input value is required");
        }
    }

}

    public void setValue(String value) {
        this.value = value;
    }
}
