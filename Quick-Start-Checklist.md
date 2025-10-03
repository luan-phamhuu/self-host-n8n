# ✅ n8n AWS Quick Start Checklist

Use this checklist to track your progress!

## Pre-Setup

- [ ] AWS account created and verified
- [ ] Credit card added to AWS account
- [ ] Chosen AWS region (closest to you)

## Step 1: AWS Infrastructure

- [ ] Security group created with HTTP/HTTPS/SSH rules
- [ ] EC2 instance launched (Ubuntu 22.04 LTS)
- [ ] Key pair (.pem file) downloaded securely
- [ ] Instance accessible via SSH

## Step 2: Server Setup

- [ ] Connected to EC2 instance via SSH
- [ ] System updated (`sudo apt-get update && upgrade`)
- [ ] Docker installed
- [ ] Docker Compose installed
- [ ] User added to docker group

## Step 3: n8n Configuration

- [ ] Created `~/n8n/` directory
- [ ] Copied `docker-compose.yml`
- [ ] Created `.env` file with secure passwords
- [ ] Generated encryption keys and JWT secret
- [ ] Updated domain/host settings

## Step 4: Launch n8n

- [ ] Started Docker containers (`docker-compose up -d`)
- [ ] Verified containers are running (`docker-compose ps`)
- [ ] Checked n8n logs (`docker-compose logs n8n`)
- [ ] Can access n8n via http://YOUR-IP

## Step 5: Domain & SSL (Optional)

- [ ] Domain purchased/configured
- [ ] DNS A record pointing to EC2 IP
- [ ] SSL certificate obtained (Let's Encrypt)
- [ ] HTTPS working on your-domain.com

## Step 6: Security

- [ ] UFW firewall enabled
- [ ] Only necessary ports open (22, 80, 443)
- [ ] Strong passwords generated
- [ ] Security group properly configured

## Step 7: Monitoring & Backup

- [ ] CloudWatch monitoring configured
- [ ] Backup script created
- [ ] Cron job for daily backups
- [ ] Health check endpoint working

## Step 8: Final Testing

- [ ] n8n login working
- [ ] Can create simple workflow
- [ ] Webhook endpoints responding
- [ ] Database connections stable

## Quick Commands Reference

```bash
# Check Docker containers
docker-compose ps

# View logs
docker-compose logs -f n8n

# Restart services
docker-compose restart

# Update n8n
docker-compose pull
docker-compose up -d

# Backup database
docker-compose exec postgres pg_dump -U n8n n8n > backup.sql

# Check disk space
df -h

# Check memory usage
free -h

# Check running processes
htop
```

## Troubleshooting Quick Fixes

| Problem               | Quick Fix                                             |
| --------------------- | ----------------------------------------------------- |
| Can't access n8n      | Check security group HTTP/HTTPS rules                 |
| Container won't start | Check logs: `docker-compose logs n8n`                 |
| Database errors       | Restart PostgreSQL: `docker-compose restart postgres` |
| Out of memory         | Add swap or upgrade instance                          |
| SSL not working       | Check domain DNS and certificate renewal              |

## Cost Monitoring Tips

- [ ] Set up billing alerts in AWS Console
- [ ] Monitor EC2 usage daily
- [ ] Check for any unexpected charges
- [ ] Use AWS Cost Explorer

---

✅ **All done?** You now have a production-ready n8n instance!
