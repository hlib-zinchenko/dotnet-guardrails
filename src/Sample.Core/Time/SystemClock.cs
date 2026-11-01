namespace Sample.Core.Time;

public sealed class SystemClock : IClock
{
    [SuppressMessage(
        "ApiDesign",
        "RS0030:Do not use banned APIs",
        Justification = "The one place allowed to read the system clock.")]
    public DateTimeOffset UtcNow => DateTimeOffset.UtcNow;
}
