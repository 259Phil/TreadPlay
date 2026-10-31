void unlock(String asset) {}

/// Returns false: no own audio here, the caller uses the system click.
bool play(String asset, double gain, Duration minGap) => false;

bool preview(String asset, double gain) => false;

void preload(List<String> assets) {}
