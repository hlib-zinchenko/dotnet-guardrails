namespace Sample.Core.Entities;

public sealed class Order : Entity<OrderId>
{
    private readonly List<string> _lines = [];

    public Order(OrderId id, DateTimeOffset placedAt)
        : base(id)
    {
        PlacedAt = placedAt;
    }

    public DateTimeOffset PlacedAt { get; private set; }

    public IReadOnlyCollection<string> Lines => _lines;

    public void AddLine(string line)
    {
        _lines.Add(line);
    }
}
