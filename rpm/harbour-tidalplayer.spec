# 
# Do NOT Edit the Auto-generated Part!
# Generated by: spectacle version 0.32
# 

Name:       harbour-tidalplayer

# >> macros
# << macros

%{!?qtc_qmake:%define qtc_qmake %qmake}
%{!?qtc_qmake5:%define qtc_qmake5 %qmake5}
%{!?qtc_make:%define qtc_make make}
%{?qtc_builddir:%define _builddir %qtc_builddir}
Summary:    Tidal player for Sailfish OS
Version:    0.0.2
Release:    1
Group:      Qt/Qt
License:    LICENSE
URL:        https://github.com/sailfishos
Source0:    %{name}-%{version}.tar.bz2
Source100:  harbour-tidalplayer.yaml
Requires:   sailfishsilica-qt5 >= 0.10.9
Requires:   pyotherside-qml-plugin-python3-qt5
Requires:   libsailfishapp-launcher
Requires:   python3-requests
Requires:   python3-future
Requires:   python3-dateutil
Requires:   python3-six
BuildRequires:  pkgconfig(sailfishapp) >= 1.0.2
BuildRequires:  pkgconfig(Qt5Core)
BuildRequires:  pkgconfig(Qt5Qml)
BuildRequires:  pkgconfig(Qt5Quick)
BuildRequires:  pkgconfig(python3)
BuildRequires:  desktop-file-utils

%description
A Sailfish OS sample application written in Python.


%prep
%setup -q -n %{name}-%{version}

# >> setup
# << setup

%build
# >> build pre
# << build pre

%qtc_qmake5 

%qtc_make %{?_smp_mflags}

# >> build post
# << build post

%install
rm -rf %{buildroot}
# >> install pre
# << install pre
%qmake5_install

# >> install post
mkdir %{buildroot}%{_datadir}/%{name}/python
cp -r python/tidalapi  %{buildroot}%{_datadir}/%{name}/python/tidalapi
sed -i  '114d'  %{buildroot}%{_datadir}/%{name}/python/tidalapi/user.py
# << install post

desktop-file-install --delete-original       \
  --dir %{buildroot}%{_datadir}/applications             \
   %{buildroot}%{_datadir}/applications/*.desktop

%files
%defattr(-,root,root,-)
%{_datadir}/%{name}
%{_datadir}/applications/%{name}.desktop
%{_datadir}/icons/hicolor/86x86/apps/%{name}.png
# >> files
# << files