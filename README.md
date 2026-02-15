# T480 Control Plane Workstation

> Enterprise-grade Linux workstation management demonstrating system administration, automation, and monitoring capabilities.

## Overview

This project showcases the complete management of a ThinkPad T480 running Fedora Linux as a control plane workstation for infrastructure operations. The implementation demonstrates professional system administration capabilities including automated configuration, security hardening, development environment setup, and comprehensive monitoring.

The T480 serves as the primary administrative workstation for managing infrastructure services, executing Ansible playbooks, running CI/CD pipelines, and maintaining observability across the lab environment.

## Architecture

**Control Plane Workstation Architecture**:
- **Operating System**: Fedora Linux with custom kernel configuration
- **Window Manager**: Sway (Wayland) with optimized laptop configuration
- **Development Environment**: Vi-centric toolchain with AI integration
- **Automation Hub**: Ansible control plane for infrastructure management
- **Monitoring Node**: Local Prometheus/Grafana for system observability
- **Security Layer**: Firewalld, SSH hardening, and credential management

**Key Services**:
- **Ansible**: Infrastructure automation and deployment
- **Forgejo**: Local Git server with CI/CD capabilities
- **Ollama**: Local AI/LLM services for development assistance
- **OpenCode**: AI-powered development environment integration
- **Prometheus/Grafana**: System monitoring and visualization
- **Syncthing**: File synchronization and backup management

## Key Demonstrations

### System Administration
- **Workstation Hardening**: Security baseline implementation with firewalld, SSH configuration, and user management
- **Laptop Optimization**: Touchpad, trackpoint, and fingerprint reader configuration for mobile productivity
- **Performance Tuning**: System optimization for development and infrastructure tasks
- **Backup & Recovery**: Comprehensive backup strategy with Syncthing and rsync automation

### Infrastructure Automation
- **Ansible Mastery**: Complete playbooks for workstation and server management
- **CI/CD Pipeline**: Forgejo Actions integration for automated testing and deployment
- **Configuration Management**: Idempotent system configuration with role-based Ansible structure
- **Service Management**: Automated deployment and management of infrastructure services

### Development Environment
- **Vi-Centric Workflow**: Professional Vim/Neovim configuration with modern tooling integration
- **AI Integration**: Local Ollama services with OpenCode for AI-assisted development
- **Version Control**: Professional Git workflow with branching, merging, and CI integration
- **Documentation-Driven**: Comprehensive documentation with ADRs, runbooks, and troubleshooting guides

### Monitoring & Observability
- **System Metrics**: Prometheus configuration for comprehensive system monitoring
- **Visualization**: Grafana dashboards for system performance and resource utilization
- **Log Management**: Centralized logging and analysis capabilities
- **Alerting**: Proactive monitoring with configurable alert thresholds

## Documentation

- **[Architecture Decisions](ADR/)** - Technical decisions and rationale
- **[Runbooks](docs/runbooks/)** - Operational procedures
- **[Troubleshooting](docs/troubleshooting/)** - Issue resolution guides
- **[Architecture](docs/architecture/)** - System design documentation
- **[Diagrams](diagrams/)** - System visualizations

## Technology Stack

- **Operating System**: Fedora Linux (latest stable)
- **Window Manager**: Sway (Wayland) with custom configuration
- **Automation**: Ansible with role-based structure
- **Version Control**: Forgejo (Gitea fork) with Actions CI/CD
- **AI Services**: Ollama with OpenCode integration
- **Monitoring**: Prometheus + Grafana stack
- **Development**: Vim/Neovim with modern tooling
- **Synchronization**: Syncthing for file management

## Project Status

**Current Version**: v1.0.0  
**Last Updated**: February 2026  
**Maintenance**: Active - Continuously improving with new capabilities

## Professional Context

This project demonstrates enterprise-grade infrastructure capabilities including:
- **System Administration**: Complete workstation management and security hardening
- **Infrastructure as Code**: Ansible automation with role-based configuration
- **Development Operations**: CI/CD pipeline implementation and management
- **Monitoring & Observability**: Comprehensive system monitoring and alerting
- **Documentation Excellence**: Professional documentation with ADRs and operational procedures

### Key Achievements

#### Security Implementation
- Implemented comprehensive firewall configuration with firewalld
- Configured SSH hardening with key-based authentication
- Established secure credential management practices
- Created security baseline for workstation deployment

#### Automation Excellence
- Developed role-based Ansible structure for reproducible configuration
- Implemented CI/CD pipeline with Forgejo Actions
- Created automated backup and recovery procedures
- Established infrastructure as code practices

#### Operational Excellence
- Built comprehensive monitoring with Prometheus and Grafana
- Created detailed runbooks for all operational procedures
- Implemented systematic troubleshooting approaches
- Established professional documentation standards

#### Development Environment
- Configured optimal Vi-centric development workflow
- Integrated AI-assisted development with local Ollama services
- Established professional Git workflow and branching strategies
- Created documentation-driven development practices

## Learning Outcomes

This project demonstrates mastery of:

### Technical Skills
- Linux system administration and security
- Infrastructure automation with Ansible
- CI/CD pipeline implementation
- System monitoring and observability
- Professional development environment setup

### Professional Practices
- Documentation-driven development
- Infrastructure as code methodologies
- Security-first approach to system management
- Systematic troubleshooting and problem-solving
- Professional workflow optimization

### Enterprise Readiness
- Scalable system configuration approaches
- Standardized operational procedures
- Comprehensive monitoring and alerting
- Professional documentation and knowledge management
- Automated backup and recovery strategies

---

*This project is part of a professional infrastructure portfolio showcasing practical system administration and engineering capabilities suitable for enterprise environments.*

## Portfolio Context

This T480 workstation management project is part of a comprehensive infrastructure portfolio that includes:

- **[SRV-M1M Platform](https://github.com/ch1ch0-foss/labs-srv-m1m)** - High-performance ARM infrastructure platform
- **[Professional Portfolio](https://github.com/ch1ch0-foss/portfolio)** - Complete professional profile and resume
- **[ChiCho FOSS](https://github.com/ch1ch0-foss/ch1ch0-foss)** - Open source contributions and projects

---

*Building enterprise-grade infrastructure with professional standards and comprehensive documentation.*