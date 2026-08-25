(() => {
  "use strict";

  const STORAGE_KEY = "microserver-toc-state";
  const COLLAPSED = "collapsed";
  const EXPANDED = "expanded";

  // Material for MkDocs에서 오른쪽 TOC가 독립 Sidebar로 표시되는 폭 이상에서만
  // 별도 TOC 토글을 사용한다.
  const desktopQuery = window.matchMedia("(min-width: 60em)");

  // 저장된 사용자 선택이 없으면 노트북/작은 데스크톱에서는 TOC를 접어
  // 본문 폭을 우선 확보한다. 1800px보다 넓은 화면에서는 기본 표시한다.
  const notebookQuery = window.matchMedia("(max-width: 112.5em)");

  let button = null;

  function readSavedState() {
    try {
      const value = window.localStorage.getItem(STORAGE_KEY);
      return value === COLLAPSED || value === EXPANDED ? value : null;
    } catch (_) {
      return null;
    }
  }

  function saveState(state) {
    try {
      window.localStorage.setItem(STORAGE_KEY, state);
    } catch (_) {
      // Storage가 차단된 환경에서도 토글 자체는 동작하도록 무시한다.
    }
  }

  function resolveInitialState() {
    const saved = readSavedState();
    if (saved) return saved;

    return notebookQuery.matches ? COLLAPSED : EXPANDED;
  }

  function hasToc() {
    const sidebar = document.querySelector(".md-sidebar--secondary");
    if (!sidebar) return false;

    // 페이지별 hide: toc 또는 제목이 거의 없는 페이지에서는 버튼도 숨긴다.
    return Boolean(sidebar.querySelector(".md-nav__link"));
  }

  function updateButton(state) {
    if (!button) return;

    const collapsed = state === COLLAPSED;
    button.classList.toggle("is-collapsed", collapsed);
    button.setAttribute("aria-expanded", String(!collapsed));
    button.setAttribute(
      "aria-label",
      collapsed ? "문서 목차 펼치기" : "문서 목차 접기"
    );
    button.setAttribute(
      "title",
      collapsed ? "목차 펼치기" : "목차 접기"
    );

    button.innerHTML = collapsed
      ? '<span class="toc-toggle-button__icon" aria-hidden="true">‹</span><span class="toc-toggle-button__label">목차</span>'
      : '<span class="toc-toggle-button__label">목차 접기</span><span class="toc-toggle-button__icon" aria-hidden="true">›</span>';
  }

  function applyState(state, persist = false) {
    document.documentElement.dataset.tocState = state;
    updateButton(state);

    if (persist) saveState(state);
  }

  function ensureButton() {
    if (button && document.body.contains(button)) return button;

    button = document.querySelector(".toc-toggle-button");
    if (button) return button;

    button = document.createElement("button");
    button.type = "button";
    button.className = "toc-toggle-button";

    button.addEventListener("click", () => {
      const current = document.documentElement.dataset.tocState || EXPANDED;
      const next = current === COLLAPSED ? EXPANDED : COLLAPSED;
      applyState(next, true);
    });

    document.body.appendChild(button);
    return button;
  }

  function refresh() {
    ensureButton();

    const available = desktopQuery.matches && hasToc();
    button.hidden = !available;

    if (!available) return;

    const current = document.documentElement.dataset.tocState;
    applyState(
      current === COLLAPSED || current === EXPANDED
        ? current
        : resolveInitialState()
    );
  }

  function initialize() {
    // 첫 화면에서는 저장값 또는 화면 폭을 기준으로 초기 상태를 결정한다.
    if (!document.documentElement.dataset.tocState) {
      document.documentElement.dataset.tocState = resolveInitialState();
    }

    refresh();
  }

  // 일반 페이지 로드
  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", initialize, { once: true });
  } else {
    initialize();
  }

  // 향후 navigation.instant를 활성화해도 페이지 전환 뒤 다시 TOC 유무를 검사한다.
  if (typeof document$ !== "undefined" && document$?.subscribe) {
    document$.subscribe(() => refresh());
  }

  // 화면 폭이 Material 반응형 기준점을 넘나들 때 버튼 노출 여부를 즉시 갱신한다.
  const handleViewportChange = () => {
    if (!readSavedState()) {
      applyState(resolveInitialState());
    }
    refresh();
  };

  desktopQuery.addEventListener?.("change", handleViewportChange);
  notebookQuery.addEventListener?.("change", handleViewportChange);
})();
