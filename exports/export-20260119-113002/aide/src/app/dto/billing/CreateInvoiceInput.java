package app.dto.billing;

public final class CreateInvoiceInput {
    private int amount;
    private String note;
    public int getAmount() { return amount; }
    public void setAmount(int amount) { this.amount = amount; }
    public String getNote() { return note; }
    public void setNote(String note) { this.note = note; }
    public void validate() {
        if (amount <= 0) throw new IllegalArgumentException("amount must be > 0");
    }
}
