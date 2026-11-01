using Sample.Core.Entities;

using Xunit;

namespace Sample.Core.Tests;

public class OrderTests
{
    [Fact]
    public void AddLine_WithNewLine_AppendsItToLines()
    {
        Order order = new(new OrderId(Guid.NewGuid()), new DateTimeOffset(2026, 1, 1, 0, 0, 0, TimeSpan.Zero));

        order.AddLine("Coffee");

        Assert.Equal(["Coffee"], order.Lines);
    }
}
