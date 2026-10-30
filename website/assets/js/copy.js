document.addEventListener("click", async (event) => {
  const button = event.target.closest("[data-copy]");
  if (!button) return;
  const target = document.getElementById(button.dataset.copy);
  const status = button.closest(".install-box")?.querySelector(".copy-status");
  if (!target) return;
  const value = target.textContent.trim();
  try {
    if (navigator.clipboard && window.isSecureContext) {
      await navigator.clipboard.writeText(value);
    } else {
      const field = document.createElement("textarea");
      field.value = value;
      field.setAttribute("readonly", "");
      field.style.position = "absolute";
      field.style.left = "-9999px";
      document.body.appendChild(field);
      field.select();
      const copied = document.execCommand("copy");
      field.remove();
      if (!copied) throw new Error("Copy unavailable");
    }
    button.textContent = document.documentElement.lang === "vi" ? "✓ Đã sao chép" : "✓ Copied";
    if (status) status.textContent = document.documentElement.lang === "vi" ? "Đã sao chép lệnh cài đặt." : "Installation command copied.";
  } catch {
    if (status) status.textContent = document.documentElement.lang === "vi" ? "Không thể tự sao chép. Hãy chọn và sao chép lệnh thủ công." : "Could not copy automatically. Select and copy the command manually.";
  }
});