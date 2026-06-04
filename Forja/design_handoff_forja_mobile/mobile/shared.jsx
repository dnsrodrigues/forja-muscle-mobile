/* global React, Icon, MobStatus */
// Shared mobile shell + bottom tab bar (5 slots, center = start/continue training)

function TabBar({ active = "home" }) {
  const left = [
    { id: "home",   label: "Hoje",       icon: "home" },
    { id: "semana", label: "Semana",     icon: "calendar" },
  ];
  const right = [
    { id: "biblio", label: "Exercícios", icon: "dumbbell" },
    { id: "perfil", label: "Perfil",     icon: "user" },
  ];
  return (
    <div className="tabbar">
      {left.map((t) => (
        <div key={t.id} className={"tabbar-item" + (active === t.id ? " active" : "")}>
          <Icon name={t.icon} size={22}/>{t.label}
        </div>
      ))}
      <div className="tabbar-fab">
        <Icon name="play" size={26}/>
      </div>
      {right.map((t) => (
        <div key={t.id} className={"tabbar-item" + (active === t.id ? " active" : "")}>
          <Icon name={t.icon} size={22}/>{t.label}
        </div>
      ))}
    </div>
  );
}

// Phone shell: status bar at top, content area, optional tab bar
function Phone({ children, tab = null, dark = false, statusTime = "07:42" }) {
  return (
    <div className="mob" style={{ background: dark ? '#050506' : 'var(--bg-0)' }}>
      <MobStatus time={statusTime}/>
      {children}
      {tab !== null && <TabBar active={tab}/>}
    </div>
  );
}

// Reusable top header with big title + optional right action
function MobHead({ over, title, right }) {
  return (
    <div className="mob-head">
      <div>
        {over && <div style={{ fontSize: 11, color: 'var(--text-dim)', letterSpacing: '0.15em', textTransform:'uppercase' }}>{over}</div>}
        <h1>{title}</h1>
      </div>
      {right}
    </div>
  );
}

function BackHead({ title, right }) {
  return (
    <div style={{ display:'flex', alignItems:'center', justifyContent:'space-between', padding:'6px 18px 12px' }}>
      <button style={{ background:'transparent', border:'none', color:'var(--text)' }}>
        <Icon name="arrowL" size={24}/>
      </button>
      <div className="eyebrow" style={{ fontSize: 11 }}>{title}</div>
      <div style={{ width: 24, display:'flex', justifyContent:'flex-end' }}>{right || <span style={{ width:24 }}/>}</div>
    </div>
  );
}

Object.assign(window, { TabBar, Phone, MobHead, BackHead });
